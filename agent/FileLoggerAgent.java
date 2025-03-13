import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.lang.instrument.Instrumentation;
import java.security.ProtectionDomain;
import java.net.URL;
import java.time.LocalDateTime;

public class FileLoggerAgent {
    
    private static PrintWriter logWriter;

    public static void premain(String args, Instrumentation inst) {
        try {
            logWriter = new PrintWriter(new FileWriter("loaded-classes.log", true), true);
        } catch (IOException e) {
            System.err.println("Erro ao abrir arquivo de log: " + e.getMessage());
            return;
        }

        inst.addTransformer(new ClassFileTransformer() {
            @Override
            public byte[] transform(ClassLoader loader,
                                    String className,
                                    Class<?> classBeingRedefined,
                                    ProtectionDomain protectionDomain,
                                    byte[] classfileBuffer) throws IllegalClassFormatException {

                logClass(className, protectionDomain);
                return null;  // não modifica o bytecode
            }
        });

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            if (logWriter != null) {
                logWriter.close();
            }
        }));
    }

    private static synchronized void logClass(String className, ProtectionDomain domain) {
        String classFormatted = className.replace('/', '.');
        String resource = "Unknown Source";

        if (domain != null && domain.getCodeSource() != null) {
            URL url = domain.getCodeSource().getLocation();
            resource = url.toString();
        }

        logWriter.printf("%s,%s,%s%n", LocalDateTime.now(), classFormatted, resource);
    }
}
