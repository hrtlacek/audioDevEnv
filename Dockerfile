FROM continuumio/miniconda3
MAINTAINER Patrik Lechner <ptrk.lechner@gmail.com>

# REQUIRES:
# KATZI repository

RUN conda install jupyterlab
# Node js needed for jupyter widgets and bokeh
RUN conda install -c conda-forge nodejs
# Install ipywidgtes
RUN conda install -c conda-forge ipywidgets
#Install/Activate the Jupyter lab extension
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager

RUN apt-get update --fix-missing && \
	apt-get install -y build-essential wget make vim cmake libncurses5-dev llvm pkg-config libmicrohttpd12 libmicrohttpd-dev g++ git-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#COPY ./KATZI /root/KATZI

#RUN git clone https://github.com/hrtlacek/KATZI.git

WORKDIR /root

RUN git clone https://github.com/grame-cncm/faust.git && cd faust && git checkout b39c5e893f80d042e41a32a9ac200e90d44ba71b

RUN git clone https://github.com/hrtlacek/faust_python.git

WORKDIR /root/faust

# current FAUST has the libraries as submodule
RUN git submodule update --init

RUN make && make install && make clean

RUN conda install cffi numpy scipy matplotlib pandas

WORKDIR /root/faust_python
# python setup.py install will cause error (faustBlabla.egg is not a directory or something)
RUN python setup.py develop

COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

WORKDIR /root
EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]

