import AssemblyKeys._

seq(assemblySettings: _*)

name := "scala-storm-starter"

version := "0.0.2-SNAPSHOT"

scalaVersion := "2.9.2"

fork in run := true

resolvers ++= Seq(
  "twitter4j" at "http://twitter4j.org/maven2",
  "clojars.org" at "http://clojars.org/repo"
)

libraryDependencies ++= Seq(
  "com.rabbitmq" % "amqp-client" % "3.1.1",
  "storm" % "storm" % "0.9.0" % "provided",
  "org.clojure" % "clojure" % "1.4.0" % "provided",
  "org.twitter4j" % "twitter4j-core" % "2.2.6-SNAPSHOT",
  "org.twitter4j" % "twitter4j-stream" % "2.2.6-SNAPSHOT",
  "org.specs2" %% "specs2" % "1.11" % "test",
  "com.datastax.cassandra" % "cassandra-driver-core" % "1.0.3",
  "com.yammer.metrics" % "metrics-core" % "2.2.0"
  // "javax.servlet" % "servlet-api" % "2.5-20081211" intransitive
)



excludedJars in assembly <<= (fullClasspath in assembly) map { cp =>
  cp filter { f => 
    f.data.getName == "servlet-api-2.5.jar"
  }
}
// f.data.getName == "log4j-over-slf4j.jar" 


mainClass in Compile := Some("storm.starter.topology.ExclamationTopology")

mainClass in assembly := Some("storm.starter.topology.ExclamationTopology")

TaskKey[File]("generate-storm") <<= (baseDirectory, fullClasspath in Compile, mainClass in Compile) map { (base, cp, main) =>
  val template = """#!/bin/sh
java -classpath "%s" %s "$@"
"""
  val mainStr = main getOrElse error("No main class specified")
  val contents = template.format(cp.files.absString, mainStr)
  val out = base / "bin/run-main-topology.sh"
  IO.write(out, contents)
  out.setExecutable(true)
  out
}
