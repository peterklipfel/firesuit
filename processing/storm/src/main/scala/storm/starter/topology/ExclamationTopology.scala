package storm.starter.topology

import backtype.storm.{ Config, LocalCluster, StormSubmitter }
import backtype.storm.testing.TestWordSpout
import backtype.storm.topology.TopologyBuilder
import backtype.storm.utils.Utils
import storm.starter.amqp._
import storm.starter.spout._
import storm.starter.cassandra._
import storm.starter.config._
import storm.starter.bolt.TokenizerBolt

object ExclamationTopology {
  def main(args: Array[String]) {

    val builder: TopologyBuilder = new TopologyBuilder()

    val reader = new FiresuitConfig()
    val firesuitConf = reader.getConfig()

    println(firesuitConf("rabbitip"))
    println(firesuitConf("cassandraip"))

    // builder.setSpout("word", new TestWordSpout(), 10)

    builder.setSpout("rabbitmq", new AMQPSpout(firesuitConf("rabbitip"), 5672, "guest", "guest", "/", new ExclusiveQueueWithBinding("stormExchange", "exclaimTopology"), new AMQPScheme()), 10)
    builder.setBolt("rawJSONtoCassandra", new CassandraRawStorer(firesuitConf("cassandraip")), 2).shuffleGrouping("rabbitmq")
    builder.setBolt("parsewords", new TokenizerBolt(), 3).shuffleGrouping("rawJSONtoCassandra")
    builder.setBolt("storeWords", new CassandraCounterStorer(firesuitConf("cassandraip")), 9).shuffleGrouping("parsewords")

    val config = new Config()
    config.setDebug(true)

    if (args != null && args.length > 0) {
      config.setNumWorkers(3)
      StormSubmitter.submitTopology(args(0), config, builder.createTopology())
    } else {
      // config.setNumWorkers(3)
      // StormSubmitter.submitTopology("ExclamationTopology", config, builder.createTopology())
      val cluster: LocalCluster = new LocalCluster()
      cluster.submitTopology("ExclamationTopology", config, builder.createTopology())
      // Utils.sleep(5000)
      // cluster.killTopology("ExclamationTopology")
      // cluster.shutdown()
    }
  }
}
