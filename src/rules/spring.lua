local _M = {
    name = "Spring Boot",
    desc = " Spring Boot敏感路径检测。",
    level = "medium",
    position = "uri", -- 只检查uri
    rules = {
        {
          pattern = [[ /actuator(/auditLog|/auditevents|/autoconfig|/beans|/caches|/conditions|/configurationMetadata|/configprops|/dump|/env|/events|/exportRegisteredServices|/features|/flyway|/health|/heapdump|/healthcheck|/httptrace|/hystrix.stream|/info|/integrationgraph|/jolokia|/logfile|/loggers|/loggingConfig|/liquibase|/metrics|/mappings|/scheduledtasks|/swagger-ui.html|/prometheus|/refresh|/registeredServices|/releaseAttributes|/resolveAttributes|/sessions|/springWebflow|/shutdown|/sso|/ssoSessions|/statistics|/status|/threaddump|/trace)? ]],
          name = "Actuator Path Access",
          confidence = 2
        },
        {
          pattern = [[ api(/index\.html|/swagger-ui\.html|/v2/api-docs)? ]],
          name = "API Documentation Access",
          confidence = 2
        },
        {
          pattern = [[ druid(/index\.html|/login\.html|/websession\.html)? ]],
          name = "Druid Path Access",
          confidence = 2
        },
        {
          pattern = [[ /heapdump(\.json)? ]],
          name = "Heapdump Path Access",
          confidence = 3
        },
        {
          pattern = [[ swagger-ui ]],
          name = "SW Swagger UI Path Access",
          confidence = 2
        },
        {
          pattern = [[ swagger(/codes|/index.html|/static/index\.html|/swagger-ui\.html)? ]],
          name = "Swagger Path Access",
          confidence = 2
        },
    }
      
  }
  
  return _M
  