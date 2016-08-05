
return '// MARK: - Immutable\n\n'
 + extensions.Immutable.map(function(object) {
    if (object.isEnum) {
      return ''
    }
    return `extension ${object.name} {\n`
      + object.fields.map(function(field) {
        return `${field.accessibility} func set(${field.name} ${field.name}: ${field.type }) -> ${object.name} {\n  return `
          + constructorCall(object)
          + '}'
      }).join('\n')
      + '}\n\n';
  }).join('\n\n')


function constructorCall(object) {
    return object.name
    + '('
    + object.fields.map(function(field) { return `${field.name}: ${field.name}` }).join(',')
    + ')'
}
