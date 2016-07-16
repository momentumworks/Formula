

return extensions.Immutable.map(function(object) {
  return `extension ${object.name} {\n`
    + object.fields.map(function(field) {
      return `${field.accessibility} func set(${field.name} ${field.name}: ${field.type }) -> ${object.name} { return `
        + constructorCall(object)
        + '}\n'
    })
    + '}\n\n';
})


function constructorCall(object) {
    return object.name
    + '('
    + object.fields.map(function(field) { return `${field.name}: ${field.name}` }).join(',')
    + ')'
}
