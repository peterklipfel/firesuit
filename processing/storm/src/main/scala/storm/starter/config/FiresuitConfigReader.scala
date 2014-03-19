package storm.starter.config

import collection.JavaConversions._
import com.fasterxml.jackson.annotation.JsonProperty
import java.io.{FileReader, FileNotFoundException, IOException}
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;

class FiresuitConfigReader {
  def getConfig(): FiresuitConfig = {
    val reader = new FileReader("/var/firesuit/config.yml")
    val mapper = new ObjectMapper(new YAMLFactory())
    val config: FiresuitConfig = mapper.readValue(reader, classOf[FiresuitConfig])
    return config
  }
}
