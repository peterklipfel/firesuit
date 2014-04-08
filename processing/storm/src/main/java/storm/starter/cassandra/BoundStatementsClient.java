package storm.starter.cassandra;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.BoundStatement;
import java.math.BigDecimal;

public class BoundStatementsClient extends SimpleClient {
    public void loadData(String json) {
        PreparedStatement statement = getSession().prepare(
            "INSERT INTO stormks.rawdata " +
            "(time, json) " +
            "VALUES (?, ?);"
        );
        double unixTime = System.currentTimeMillis() / 1000;
        java.math.BigDecimal cqlTime = new java.math.BigDecimal(unixTime);
        BoundStatement boundStatement = new BoundStatement(statement);
        getSession().execute(boundStatement.bind(
            cqlTime,
            json) 
        );
    }

    public void countWord(String word) {
        // TODO: This hack is here because the "?" interpolation wasn't working
        PreparedStatement statement = getSession().prepare(
          "UPDATE stormks.wordcount " +
           "SET counter_value = counter_value + 1 " +
           "WHERE word='"+word+"';"
        );
        BoundStatement boundStatement = new BoundStatement(statement);
        getSession().execute(boundStatement );
    }
}
