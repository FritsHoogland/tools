alter system set memory_target=1025M comment='Set by VX. Production like settings.' scope=spfile sid='*';
alter system set processes=1250 comment='Set by VX. Production like settings.' scope=spfile sid='*';
alter system reset large_pool_size scope=spfile sid='*';
