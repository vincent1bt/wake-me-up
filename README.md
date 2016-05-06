##Wake	Me Up App
App para iOS que te muestra noticias, ultimos tweets, clima, recordatorios y lugares para desayunar al despertar.

##Descripción

![wake me up](http://res.cloudinary.com/vincent1bt/image/upload/v1462493011/wakemeupDemo_nk9u8d.gif "Video demo")


##Api

1. Api de new york times
2. Api de twitter
3. Api de foursquare
4. Api de openweather

##Uso

Necesitan crear una app de [Twitter](https://apps.twitter.com)
con la siguiente configuración:

- Access level: Read and write
- Sign in with Twitter:	Yes

y registrarse en la api de [Foursquare](https://developer.foursquare.com/)

Despues crear un nuevo archivo tipo swift(vacio) llamado Keys.swift (el nombre puede ser el que ustedes quieran)
que tenga el siguiente codigo:

```
import Foundation

struct Keys {
struct Twitter {
    static let consumerKey: String = "consumerKey"
    static let secretKey: String = "secretKey"
}

struct Foursquare {
    static let clientId = "clientId"
    static let clientSecret = "clientSecret"
}
}
```
