create_counter <- function() {
    time_s <- NA
    time_e <- NA
    b <- function() {
        time_s <<- Sys.time()
    }
    e <- function() {
        time_e <<- Sys.time()
    }
    p <- function() {
        time_e - time_s
    }
    structure(list(start = b, stop = e, print = p), class = "estimationtime")
}

print.estimationtime <- function(x, ...) {
    print(x$print())
}
