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

  def getConfig(): Map[String, String] = {
    
    val stringifiedFile = io.Source.fromFile("/var/firesuit/config.yml").mkString
    val rabbitPattern = "rabbitip: (.*)\n".r

    var rabbitip = ""
    rabbitPattern.findAllIn(stringifiedFile).matchData.foreach {
      m => rabbitip = m.group(1)
    }

    val cassandraPattern = "cassandraip: (.*)\n".r
    var cassandraip = ""
    cassandraPattern.findAllIn(stringifiedFile).matchData.foreach {
      m => cassandraip = m.group(1)
    }

    return Map("rabbitip" -> rabbitip, "cassandraip" -> cassandraip)
  }
}