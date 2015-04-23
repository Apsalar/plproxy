provider plproxy {

   probe main__error(char * name, int arg_count, char * msg);

   probe proxy__execstart();

   probe proxy__execdone();

   probe proxy__execexcept();

   probe shard__connprep();

   probe shard__connready();

   probe shard__sendstart();

   probe shard__senddone();

   probe shard__resultswait();

   probe shard__resultsrcvd();

   probe shard__resultsdone();
};
