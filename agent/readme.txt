javac FileLoggerAgent.java
jar cmf MANIFEST.MF file-logger-agent.jar FileLoggerAgent.class FileLoggerAgent\$1.class

java -javaagent:file-logger-agent.jar -jar MinhaAplicacao.jar

export JAVA_TOOL_OPTIONS="-javaagent:file-logger-agent.jar"

