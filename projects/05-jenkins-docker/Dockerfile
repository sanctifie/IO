FROM tomcat:9.0-jdk17
# webapps est vide dans l'image officielle : on remet les applications par défaut (optionnel)
RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
COPY ./*.war /usr/local/tomcat/webapps/
