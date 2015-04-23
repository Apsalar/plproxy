provider plproxy {

/* Error handler */

   probe main__error(char * name, int arg_count, char * msg);

};
