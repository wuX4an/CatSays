import 'dart:io';
import 'dart:convert';

void main() {
  catSays();
}

void catSays() async {
  //# Fetch Data
  Future<String> fetchData() async {
    //! Firt API
    var url = 'https://catfact.ninja/fact';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();

    var jsonString = await response.transform(Utf8Decoder()).join();
    var json = JsonDecoder().convert(jsonString);

    var fact = json['fact'].toString();
    List<String> treeFWS = fact.split(' ').sublist(0, 3);

    //! Second API
    url = 'https://cataas.com/cat/says/${treeFWS.join(' ')}?fontSize=50&fontColor=white';
    return url;
  }

  //! Server
  final server = await HttpServer.bind(('localhost'), 8080);
  stdout.writeln('+ Running on http://localhost:8080');

  //# Create Server
  void processRequest(HttpRequest request) async {
    final response = request.response;
    if (request.uri.path == '/') {
      final url = await fetchData();
      final template = '''
      <head>
      <meta content="width=device-width; height=device-height;">
      <link rel="stylesheet" href="resource://content-accessible/ImageDocument.css">
      <link rel="stylesheet" href="resource://content-accessible/TopLevelImageDocument.css">
      </head>
      <body>
          <img src="$url" alt="$url">
      </body>
            ''';
      response
        ..headers.contentType = ContentType(
          'text',
          'html',
        )
        ..write(template);
    } else {
      response.statusCode = HttpStatus.notFound;
    }

    stdout.writeln('${request.uri.path} -- ${response.statusCode}');
    response.close();
  }

  await for (final request in server) {
    processRequest(request);
  }
}
