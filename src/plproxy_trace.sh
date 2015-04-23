#!/bin/sh
/usr/sbin/dtrace -n '

plproxy*:::main-error
{
    printf("%s(%d): %s", copyinstr(arg0), arg1, copyinstr(arg2));
}

plproxy*:::proxy-execstart
{
    printf("<placeholder>");
}

plproxy*:::proxy-execdone
{
    printf("<placeholder>");
}

plproxy*:::proxy-execexcept
{
    printf("<placeholder>");
}

plproxy*:::shard-connprep
{
    printf("<placeholder>");
}

plproxy*:::shard-connready
{
    printf("<placeholder>");
}

plproxy*:::shard-sendstart
{
    printf("<placeholder>");
}

plproxy*:::shard-senddone
{
    printf("<placeholder>");
}

plproxy*:::shard-resultswait
{
    printf("<placeholder>");
}

plproxy*:::shard-resultsrcvd
{
    printf("<placeholder>");
}

plproxy*:::shard-resultsdone
{
    printf("<placeholder>");
}

'
