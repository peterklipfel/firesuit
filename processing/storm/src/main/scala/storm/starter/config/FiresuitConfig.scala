package storm.starter.config

import collection.JavaConversions._
import com.fasterxml.jackson.annotation.JsonProperty
import java.io.{FileReader, FileNotFoundException, IOException}
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;

class FiresuitConfig(
  @JsonProperty("cassandraip") _cassandraip: String,
             @JsonProperty("rabbitip") _rabbitip: String) {
  val cassandraip = _cassandraip
  val rabbitip: String = _rabbitip
}

