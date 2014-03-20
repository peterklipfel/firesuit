import AssemblyKeys._

seq(assemblySettings: _*)

name := "scala-storm-starter"

version := "0.0.2-SNAPSHOT"

scalaVersion := "2.9.2"

fork in run := true

net.virtualvoid.sbt.graph.Plugin.graphSettings

resolvers ++= Seq(
  "twitter4j" at "http://twitter4j.org/maven2",
  "clojars.org" at "http://clojars.org/repo"
)

libraryDependencies ++= Seq(
  "com.rabbitmq" % "amqp-client" % "3.1.1"
    exclude ("log4j", "log4j"),
  "storm" % "storm" % "0.9.0" % "provided",
    // exclude ("org.slf4j", "slf4j-parent"),
    // exclude ("org.slf4j", "log4j-over-slf4j"),
  "org.clojure" % "clojure" % "1.4.0" % "provided"
    exclude ("log4j", "log4j"),
  "org.twitter4j" % "twitter4j-core" % "2.2.6-SNAPSHOT"
    exclude ("log4j", "log4j"),
  "org.twitter4j" % "twitter4j-stream" % "2.2.6-SNAPSHOT"
    exclude ("log4j", "log4j"),
  "org.specs2" %% "specs2" % "1.11" % "test"
    exclude ("log4j", "log4j"),
  "com.datastax.cassandra" % "cassandra-driver-core" % "1.0.3"
    exclude ("org.slf4j", "slf4j-api")
    exclude ("org.slf4j", "slf4j-log4j12")
    exclude ("log4j", "log4j"),
  "com.yammer.metrics" % "metrics-core" % "2.2.0"
    exclude ("log4j", "log4j"),
  "org.yaml" % "snakeyaml" % "1.8"
    exclude ("log4j", "log4j")
  // "com.fasterxml.jackson.core" % "jackson-core" % "2.1.1",
  // "com.fasterxml.jackson.core" % "jackson-annotations" % "2.1.1",
  // "com.fasterxml.jackson.core" % "jackson-databind" % "2.1.1",
  // "com.fasterxml.jackson.dataformat" % "jackson-dataformat-yaml" % "2.1.1"
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
