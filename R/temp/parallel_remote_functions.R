#' Initial Clusters
#' 
#' Initial clusters for parallel computing based on parallel package
#' 
#' @param ncluster How many clusters to open?
#' @param pkgs loaded packages for every cluster
#' @param vars common variables for every cluster
#' @param expr expressions to be evaluated for every cluster
#' 
#' @examples 
#' \dontrun{
#' cluster_Init(pkgs = "httr",
#'      expr = source("R/mainfunc/main.R", encoding = "utf-8"))
#' }
#' @export
cluster_Init <- function(ncluster = 4, pkgs, vars, expr) {
    e <- parent.frame()
    cl <- makeCluster(ncluster, type = "SOCK", outfile = "log.txt")
    pkgs_Init <- function(pkgs) {
        for (i in pkgs) 
            library(i, character.only = TRUE)
    }
    if (!missing(pkgs)){
        clusterCall(cl, pkgs_Init, pkgs)
    }
    if (!missing(vars)){
        clusterExport(cl, vars, envir = e)
    }
    if (!missing(expr)){
        # clusterEvalQ(cl, expr = expr)
        clusterCall(cl, eval, substitute(expr), env = e)
    }
    assign("cl", cl, envir = .GlobalEnv)
    
    # clusterEvalQ <- function (cl, expr) 
    #     clusterCall(cl, eval, substitute(expr), env = .GlobalEnv)
}

#' @export
clusterSCall <- function(cl, fun, ..., name = TRUE){
  Id_host <- selectHost(cl)
  hosts   <- names(Id_host)
  RESULT  <- clusterCall(cl[Id_host], fun, ...) %>% unlist()
  if (name) names(RESULT) <- hosts
  return(RESULT)
}

#' @export
clusterLCall <- function(cl, fun, ..., name=TRUE){
  Id_host <- selectHost(cl)
  hosts   <- names(Id_host)
  RESULT  <- clusterCall(cl[Id_host], fun, ...)
  if (name) names(RESULT) <- hosts
  return(RESULT)
}

#' @title get_files
#' @description  store calculated result in remote computers, and retrieve them later
#' 
#' @param indir directory where stored results
#' @param pattern certain file with assign pattern returned by dir function in 
#' remote computer indir.
#' @param full.names a logical value. If TRUE, the directory path is prepended 
#' to the file names to give a relative file path. If FALSE, the file names 
#' (rather than paths) are returned.
#' @export
get_files <- function(indir, pattern="*.txt", full.names = F){
  files <- NULL
  if (dir.exists(indir)) files <- dir(indir, pattern=pattern, full.names = full.names)
  return(files)#if dir don't exist then return NULL
}

#' @title selectHost
#' @description select unique hosts to excute initial check functions
#' @param cl returned by makePSOCKcluster
#' @return matched unique hosts Id positions
#' @export
selectHost <- function(cl){
  hosts <- sapply(cl, `[[`, "host")
  Id <- match(unique(hosts), hosts); names(Id) <- unique(hosts);
  # print(Id)
  return(Id)
}

#' @title sysinfo
#' 
#' Get CPU and MEMORY information of parallel remote computers. About 1.6s 
#' return the information
#' 
#' @param client List object
#' \itemize{
#' \item `rshcmd` The command to be run on the master to launch a process 
#' on another host. Defaults to ssh.
#' \item `user` The user name to be used when communicating with another host.
#' \item `host` Host ip or name
#' }
#' @export
sysinfo <- function(client){
  # Sys.info()
  if (client$host == "localhost"){
    cmd_login <- ""
  }else{
    cmd_login <- sprintf("%s %s@%s ", client$rshcmd, client$user, client$host)
  }
  # system.time({
  cpu <- system(paste0(cmd_login,"wmic cpu get loadpercentage,NumberOfLogicalProcessors /format:value"), wait=F,intern=T)
  memo.total <- system(paste0(cmd_login,"%SystemRoot%\\System32\\wbem\\wmic.exe ComputerSystem get TotalPhysicalMemory /format:value"), 
                      wait=F,intern=T)
  memo.free <- system(paste0(cmd_login,"%SystemRoot%\\System32\\wbem\\wmic.exe OS get FreePhysicalMemory /format:value"), 
                     wait=F,intern=T)
  # })
  ## extact information from cmd results
  tryCatch({
    vars <- c("CPU_used", "CPU_cores", "Memo_free", "Memo_total")
    info.str <- c(cpu, memo.free, memo.total) %>% .[-grep("^\\r", .)] %>% gsub("\\r", "", .) 
    info <- str_extract(info.str,"\\d{1,}") %>% as.numeric(.)
    n <- length(info)
    if (length(info) > 4){
      #for our windows server, hava two cpu series
      x <- info[1:(n-2)] %>% matrix(., ncol = 2, byrow = T)
      cpu_cores <- sum(x[, 2])
      cpu_used <- x[, 1] %*% x[, 2] /sum(x[, 2])
      info <- c(cpu_used, cpu_cores, info[(n-1):n])
    }
    info %<>% set_names(vars) %>% as.list()
    info$Memo_free %<>% {./1024^2}
    info$Memo_total %<>% {./1024^3}
    info$Memo_used <- info$Memo_total - info$Memo_free
    
    cat(sprintf("CPU_cores: %d\t\tCPU_used: %.2f%%\n", info$CPU_cores, info$CPU_used))
    cat(sprintf("Memo_total: %.2f Gb\tMemo_used: %.2f Gb\n", info$Memo_total, info$Memo_used))
    return(info)
  }, 
  error=function(e) {
    print(e)
    msg <- c("Plink connect error!", 
             "------------------------------------", cpu)
    warning(paste0(msg, collapse = "\n"))
  })
}
