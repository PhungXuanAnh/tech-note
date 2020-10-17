FROM mongo:4.2.9

RUN mkdir /app

ADD rs.sh /app

RUN chmod +x /app/rs.sh
