

return extensions.Immutable.map(function(object) {
  if (object.fields == undefined || object.fields == null || object.fields.length == 0) {
    return '';
  }
  return `extension ${object.name}`
    + object.fields.map(function(field) {
      return `${field.accessibility} func set(${field.name} ${field.name}: ${field.type }) -> ${object.name} { return self; }`
    })
    + '}';
})
