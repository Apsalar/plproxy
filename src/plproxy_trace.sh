#!/bin/sh
/usr/sbin/dtrace -n '

plproxy*:::main-error
{
    printf("%s(%d): %s", copyinstr(arg0), arg1, copyinstr(arg2));
}

plproxy*:::proxy-execstart
{
    printf("txid=%u oid=%u funcname=\"%s\"", arg0, arg1, copyinstr(arg2));
}

plproxy*:::proxy-execdone
{
    printf("txid=%u", arg0);
}

plproxy*:::proxy-execexcept
{
    printf("txid=%u, errcode=%d", arg0, arg1);
}

plproxy*:::proxy-cancelstart
{
    printf("txid=%u", arg0);
}

plproxy*:::proxy-canceldone
{
    printf("txid=%u", arg0);
}

plproxy*:::shard-connprep
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-connready
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-sendstart
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-senddone
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-resultswait
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-resultsrcvd
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-resultsdone
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-canceldconn
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-cancelwait
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

plproxy*:::shard-canceldone
{
    printf("txid=%u connstr=\"%s\"", arg0, copyinstr(arg1));
}

'
