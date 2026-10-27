import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/** Checks local message interpolation without external lookups or services. */
public class LogLookupSmoke {
    public static void main(String[] args) {
        Logger log = LogManager.getLogger("jvl.search");
        log.error("Search query: consulta-normal");
        log.error("Search query: " + "${java:version}");
        log.error("Search query: " + "${lower:ABC}");
        LogManager.shutdown();
    }
}
