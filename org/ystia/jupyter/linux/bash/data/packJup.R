chooseCRANmirror(ind=12)

chemin=paste(Sys.getenv("HOME"),"/R/x86_64-redhat-linux-gnu-library/3.3", sep="")
.libPaths(c(chemin,.libPaths()))

install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))
devtools::install_github('IRkernel/IRkernel')
IRkernel::installspec()
