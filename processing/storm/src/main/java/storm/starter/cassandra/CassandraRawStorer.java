package storm.starter.cassandra;

import org.apache.log4j.Logger;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseRichBolt;
import backtype.storm.tuple.Tuple;
import backtype.storm.task.OutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;
import java.util.Map;

public class CassandraRawStorer extends BaseRichBolt {
    private OutputCollector _collector;
    private static final Logger log = Logger.getLogger(CassandraRawStorer.class);
    private boolean connected = false;
    private BoundStatementsClient client;

    @Override
    public void prepare(Map conf, TopologyContext context, OutputCollector collector) {
        client = new BoundStatementsClient();
        client.connect("127.0.0.1");
        _collector = collector;
    }

    @Override
    public void execute(Tuple input) {
        log.info("tuple size: ("+input.size()+")");
        StringBuilder fields = new StringBuilder();
        String comma = "";
        for (int i=0; i<input.size(); i++) {
            fields.append(comma);
            fields.append(input.getString(i));
            comma = ", ";
        }
        // if(!connected){ connectToCassandra(); }
        client.loadData(input.getString(0));
        log.info("tuple Received: ("+fields.toString()+")");
        _collector.emit(input, new Values(input.getString(0)));
        _collector.ack(input);
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("rawJSON"));
    }

    public void connectToCassandra(){
        // client.close();
        connected = true;
    }
}
