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
}
