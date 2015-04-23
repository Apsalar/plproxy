#!/bin/sh
/usr/sbin/dtrace -n '

plproxy*:::main-error
{
    printf("%s(%d): %s", copyinstr(arg0), arg1, copyinstr(arg2));
}

plproxy*:::proxy-execstart
{
    printf("T%u", arg0);
}

plproxy*:::proxy-execdone
{
    printf("T%u", arg0);
}

plproxy*:::proxy-execexcept
{
    printf("T%u", arg0);
}

plproxy*:::shard-connprep
{
    printf("T%u %s", arg0, copyinstr(arg1));
}

plproxy*:::shard-connready
{
    printf("T%u %s", arg0, copyinstr(arg1));
}

plproxy*:::shard-sendstart
{
    printf("T%u %s", arg0, copyinstr(arg1));
}

plproxy*:::shard-senddone
{
    printf("T%u %s", arg0, copyinstr(arg1));
}

plproxy*:::shard-resultswait
{
    printf("T%u %s", arg0, copyinstr(arg1));
}

plproxy*:::shard-resultsrcvd
{
    printf("T%u %s", arg0, copyinstr(arg1));
}

plproxy*:::shard-resultsdone
{
    printf("T%u %s", arg0, copyinstr(arg1));
}

'
