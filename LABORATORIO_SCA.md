# Laboratorio de análisis de composición de software

Práctica académica de Douglas. El proyecto original pertenece a CSPF-Founder y conserva su licencia GPL-2.0.

- Fuente: https://github.com/CSPF-Founder/JavaVulnerableLab
- Commit de origen: `626a106a49777507beb51955d19ef9d271a9d4a5`.
- Entorno de análisis: Java 17; Maven 3.9.11; Dependency-Check 13.0.0; CycloneDX Maven Plugin 2.9.3.
- El estado inicial conserva las once dependencias directas originales, incluida JUnit de pruebas. El SBOM excluye pruebas y contiene 18 componentes.
- Dos archivos didácticos del original contenían cadenas con formato de claves Stripe. Se reemplazaron por `DEMO_STRIPE_SECRET_NOT_VALID` y `DEMO_STRIPE_PUBLIC_NOT_VALID` para no publicar cadenas reconocidas como secretos. Esto no altera el inventario Maven.

## Ejecución local

Definir `NVD_API_KEY` en el entorno de la sesión sin guardar su valor en Git. El archivo `.mvn/sca-settings.xml` solo referencia esa variable. No ejecutar Maven con `-X`, pues la salida de depuración puede revelar credenciales.

```powershell
mvn -B -ntp -s .mvn/sca-settings.xml org.owasp:dependency-check-maven:13.0.0:check "-Dformat=ALL" "-DnvdApiServerId=nvd" "-DossIndexAnalyzerEnabled=false"
mvn -B -ntp org.cyclonedx:cyclonedx-maven-plugin:2.9.3:makeAggregateBom "-DoutputFormat=json" "-DincludeTestScope=false"
mvn -B -ntp org.apache.maven.plugins:maven-dependency-plugin:3.8.1:tree
```

Los reportes y el SBOM se generan en `target/`, excluido de Git. El árbol confirma, por ejemplo, `JavaVulnerableLab -> hibernate-core:4.0.1.Final -> dom4j:1.6.1`.

## Pipeline

El workflow responde a push en main, PR hacia main y ejecución manual. Usa permisos `contents: read` y `security-events: write`, Java 17, secreto `NVD_API_KEY`, caché NVD por versión del analizador, formatos ALL, categoría SARIF `dependency-check` y artefactos descargables. Cada línea del YAML tiene un comentario. Un segundo job genera y publica el SBOM.

El umbral CVSS es 7. Los hallazgos altos o críticos hacen fallar el trabajo después de publicar los reportes; un error de infraestructura también falla. Que el trabajo sea rojo no significa que no se haya generado el reporte. Los PR desde forks no reciben el secreto NVD y no pueden publicar SARIF con los permisos del repositorio principal.

## Límite de la validación funcional

La compilación del código original con Java 17 falla por `javax.xml.bind` ausente en `JwtUtil.java`. Es un problema de compatibilidad previo a la remediación; el Dockerfile original construye con Java 8. Las tareas SCA y CycloneDX resuelven dependencias correctamente sin desplegar la aplicación. No se presenta este análisis como una prueba funcional de la aplicación.

## Entrega

El informe de la práctica documentará los resultados reales, las capturas, la comparación de herramientas, el PR de remediación y las cinco respuestas de análisis. No se publican claves NVD, contraseñas locales ni cachés.
