FROM gitpod/workspace-full

RUN brew install R
RUN R -e 'install.packages(c("viridis", "argparse"))'
