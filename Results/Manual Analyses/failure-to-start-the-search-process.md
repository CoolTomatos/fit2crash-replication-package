# Failure to Start the Search Process
A large number of executions have failed to start the search process with configuration [__BV__].
Notice that for frames, the control group has not reached the target line of the target frame either.
These pre-processing failures can be grouped into two categories.

## Fail to Instrument `jdk` Classes
The first category consists of crashes where there are `jdk` classes in the stack trace.
Crash __ES-23218__ is an example, of which the stack trace is shown in __[Listing 1](#listing-1-stack-trace-of-es-23218)__.

#### Listing 1: Stack Trace of ES-23218
``` log
java.lang.IllegalStateException: No match found
  at java.util.regex.Matcher.group(Matcher.java:536)
  at org.elasticsearch.monitor.os.OsProbe.getControlGroups(OsProbe.java:216)
  at org.elasticsearch.monitor.os.OsProbe.getCgroup(OsProbe.java:414)
  at org.elasticsearch.monitor.os.OsProbe.osStats(OsProbe.java:466)
  at org.elasticsearch.monitor.os.OsService.<init>(OsService.java:45)
  at org.elasticsearch.monitor.MonitorService.<init>(MonitorService.java:45)
  at org.elasticsearch.node.Node.<init>(Node.java:345)
  at org.elasticsearch.node.Node.<init>(Node.java:232)
  at org.elasticsearch.bootstrap.Bootstrap$6.<init>(Bootstrap.java:241)
  at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:241)
  at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:333)
  at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:121)
```

Due to the frequent released updates of `jdk`, Botsing developers decide not to instrument any `jdk` class to avoid discrepancies between line numbers reported in the stack trace and line numbers of the installed `jdk`.
Therefore, when our `BranchingVariableDiversityFactory` queries the method node, a `NullPointerException` is thrown, interrupting the pre-processing.
[__BV-control__] ignores the exception, however cannot move any further either without the necessary instrumentation.

## Fail to Instrument Synthetic Methods
The second category consists of crashes where the stack trace contains synthetic method frames.
Crash __ES-26184__ is an example, of which the stack trace is shown in __[Listing 2](#listing-2-stack-trace-of-es-26184)__.

#### Listing 2: Stack Trace of ES-26184

``` log
java.lang.IllegalArgumentException: invalid IP address [*] for [_ip]
  at org.elasticsearch.cluster.node.DiscoveryNodeFilters.lambda$static$0(DiscoveryNodeFilters.java:58)
  at org.elasticsearch.common.settings.Setting$3.get(Setting.java:908)
  at org.elasticsearch.common.settings.Setting$3.get(Setting.java:885)
  at org.elasticsearch.cluster.metadata.IndexMetaData$Builder.build(IndexMetaData.java:1026)
  at org.elasticsearch.cluster.metadata.IndexMetaData$Builder.fromXContent(IndexMetaData.java:1240)
  at org.elasticsearch.cluster.metadata.IndexMetaData$1.fromXContent(IndexMetaData.java:1302)
  at org.elasticsearch.cluster.metadata.IndexMetaData$1.fromXContent(IndexMetaData.java:1293)
  at org.elasticsearch.gateway.MetaDataStateFormat.read(MetaDataStateFormat.java:202)
  at org.elasticsearch.gateway.MetaDataStateFormat.loadLatestState(MetaDataStateFormat.java:322)
```

The first frame points to a lambda expression, which is transcompiled into a synthetic method in bytecode.
EvoSuite does not provide CFG for synthetic methods or classes.
Hence, when our `BranchingVariableDiversityFactory` queries the method node, a `NullPointerException` is thrown, interrupting the pre-processing.
The exception is ignored by [__BV-control__].
But it cannot proceed without the necessary instrumentation anyway.