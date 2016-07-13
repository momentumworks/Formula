

return extensions.Immutable.map(function(object) {
  return `extension ${object.name} {\n`
    + object.fields.map(function(field) {
      return `${field.accessibility} func set(${field.name} ${field.name}: ${field.type }) -> ${object.name} { return self; }\n`
    })
    + '}\n\n';
})
