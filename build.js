var fs = require('fs')

fs.readFile('./src/index.html', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  var result = data.replace(/process\.env\.npm_package_name/g, '"' + process.env.npm_package_name + '"' )
  .replace(/process\.env\.npm_package_version/g, '"' + process.env.npm_package_version + '"' );

  fs.writeFile('./index.html', result, 'utf8', function (err) {
     if (err) return console.log(err);
  });
});