package storm.starter.config

import org.yaml.snakeyaml.Yaml
import org.yaml.snakeyaml.constructor.Constructor
import scala.collection.mutable.ListBuffer
import scala.reflect.BeanProperty

// object YamlBeanTest1 {
  
//   val text = """
// accountName: Ymail Account
// username: USERNAME
// password: PASSWORD
// mailbox: INBOX
// imapServerUrl: imap.mail.yahoo.com
// protocol: imaps
// minutesBetweenChecks: 1
// usersOfInterest: [barney, betty, wilma]
// """

//   def main(args: Array[String]) {
//     val yaml = new Yaml(new Constructor(classOf[EmailAccount]))
//     val e = yaml.load(text).asInstanceOf[EmailAccount]
//     println(e)
//   }
  
// }

/**
 * With the Snakeyaml Constructor approach shown in the main method,
 * this class must have a no-args constructor.
 */
class FiresuitConfig {
  @BeanProperty var rabbitip: String = null
  @BeanProperty var cassandraip: String = null

  def getConfig(): Map[String, String] = {
    val yaml = new Yaml(new Constructor(classOf[FiresuitConfig]))
    // val path = getClass.getResource("/firesuitConfig.yml").getPath();
    val stringifiedFile = io.Source.fromFile("/var/firesuit/config.yml").mkString
    val e = yaml.load(stringifiedFile).asInstanceOf[FiresuitConfig]
    return Map("rabbitip" -> rabbitip, "cassandraip" -> cassandraip)
  }
}