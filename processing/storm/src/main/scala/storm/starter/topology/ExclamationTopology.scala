package storm.starter.topology

import backtype.storm.{ Config, LocalCluster, StormSubmitter }
import backtype.storm.testing.TestWordSpout
import backtype.storm.topology.TopologyBuilder
import backtype.storm.utils.Utils
import storm.starter.amqp._
import storm.starter.spout._
import storm.starter.cassandra._

object ExclamationTopology {
  def main(args: Array[String]) {
    import storm.starter.bolt.ExclamationBolt

    val builder: TopologyBuilder = new TopologyBuilder()

    // builder.setSpout("word", new TestWordSpout(), 10)
    builder.setSpout("rabbitmq", new AMQPSpout("localhost", 5672, "guest", "guest", "/", new ExclusiveQueueWithBinding("stormExchange", "exclaimTopology"), new AMQPScheme()), 10)
    builder.setBolt("rawJSONtoCassandra", new CassandraRawStorer(), 2).shuffleGrouping("rabbitmq")
    builder.setBolt("exclaim", new ExclamationBolt(), 3).shuffleGrouping("rawJSONtoCassandra")

    val config = new Config()
    config.setDebug(true)

    if (args != null && args.length > 0) {
      config.setNumWorkers(3)
      StormSubmitter.submitTopology(args(0), config, builder.createTopology())
    } else {
      val cluster: LocalCluster = new LocalCluster()
      cluster.submitTopology("ExclamationTopology", config, builder.createTopology())
      // Utils.sleep(5000)
      // cluster.killTopology("ExclamationTopology")
      // cluster.shutdown()
    }
  }
}
