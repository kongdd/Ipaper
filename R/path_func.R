#' convert windows path to wsl
#'
#' In windows system, conversion will not be applied.
#' @inheritParams base::normalizePath
#'
#' @export
path.mnt <- function(path) {
    sep = substr(path, 2, 2)

    if (is_wsl()) {
        if (sep == ":") {
            pan  = substr(path, 1, 1) %>% tolower()
            path = sprintf("/mnt/%s/%s", pan, substr(path, 4, nchar(path)))
        }
    }
    path
}

win_path <- function(path, winslash = "\\\\"){
    if (substr(path, 1, 4) == "/mnt") {
        pan = substr(path, 6, 6)
        path = paste0(pan, ":", substr(path, 7, nchar(path)))
    }
    gsub("/", winslash, path)
}

check_path <- function(path) {
    path = normalizePath(path)
    if (OS_type() %in% c("wsl", "windows")) {
        path <- win_path(path)
    }
    path
}

#' edit R profile by sublime
#' 
#' @export
edit_r_profile_sys <- function(){
    code(file.path(R.home(), "etc")) # /Rprofile.site
}
