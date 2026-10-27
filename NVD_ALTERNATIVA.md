# Alternativa temporal ante la falta de la clave NVD

El formulario del NVD no mostró confirmación al solicitar la clave. El trámite de activación por correo sigue pendiente y no se considera cumplido el requisito del secreto de GitHub.

Para poder ejecutar el resto de la práctica se utilizan los feeds públicos oficiales del propio NVD, mediante la opción `nvdDatafeedUrl` de Dependency-Check. Son datos reales de vulnerabilidades: no se inventan hallazgos, no se sustituye la clave por un valor ficticio y un fallo de actualización o análisis sigue haciendo fallar el trabajo.

Cuando se configure el secreto válido `NVD_API_KEY`, el mismo workflow seleccionará automáticamente la API autenticada. La clave solo se referencia mediante una variable de entorno y el servidor `nvd` de `.mvn/sca-settings.xml`.

Esta alternativa permite validar el escaneo, SARIF, artefactos, caché y comparación de remediación. No demuestra que exista el secreto solicitado en la rúbrica; ese punto requiere una clave emitida y activada por el NVD, o la aceptación expresa de esta alternativa por el docente.

Fuentes oficiales:

- https://dependency-check.github.io/DependencyCheck/dependency-check-maven/configuration.html
- https://nvd.nist.gov/vuln/data-feeds
- https://nvd.nist.gov/developers/request-an-api-key
