package storm.starter.bolt

import backtype.storm.task.{ OutputCollector, TopologyContext }
import backtype.storm.topology.base.BaseRichBolt
import backtype.storm.topology.OutputFieldsDeclarer
import backtype.storm.tuple.{ Fields, Tuple, Values }
import java.util.{ Map => JMap }
import scala.util.parsing.json._
 
 
class TokenizerBolt extends BaseRichBolt {
  var collector: OutputCollector = _

  override def prepare(config: JMap[_, _], context: TopologyContext, collector: OutputCollector) {
    this.collector = collector
  }

  override def execute(tuple: Tuple) {
    val jsonMap = JSON.parseFull(tuple.getString(0))
    jsonMap match {
      case Some(m: Map[String, _]) => {
        m.get("tweet") match {
          case Some(tweet: String) => {
            tweet.split(" +").map(x => this.collector.emit(tuple, new Values(x)))
          }
          case _ => this.collector.emit(tuple, new Values("invalid_json"))
        }
        
      }
      case None => this.collector.emit(tuple, new Values("invalid_json"))
    }

    this.collector.ack(tuple)
  }

  override def declareOutputFields(declarer: OutputFieldsDeclarer) {
    declarer.declare(new Fields("word"))
  }
}
