package storm.starter.cassandra;

// import org.apache.log4j.Logger;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseRichBolt;
import backtype.storm.tuple.Tuple;
import backtype.storm.task.OutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;
import java.util.Map;

public class CassandraCounterStorer extends BaseRichBolt {
    private OutputCollector _collector;
    // private static final Logger log = Logger.getLogger(CassandraCounterStorer.class);
    private boolean connected = false;
    private BoundStatementsClient client;
    private final String ip;

    public CassandraCounterStorer(String ip) {
        this.ip = ip;
    }

    @Override
    public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
        client = new BoundStatementsClient();
        client.connect(this.ip);
        _collector = collector;
    }

    @Override
    public void execute(Tuple input) {
        client.countWord(input.getString(0));
        // log.info("tuple Received: ("+fields.toString()+")");
        _collector.emit(input, new Values(input.getString(0)));
        _collector.ack(input);
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }

    public void connectToCassandra(){
        // client.close();
        connected = true;
    }
}
