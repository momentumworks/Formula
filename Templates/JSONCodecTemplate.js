

return '// MARK: - JSONEncodable\n\n'
 + extensions.AutoJSONEncodable.map(function(object) {
    if (object.isEnum) {
      return `extension ${object.name} : JSONEncodable {\n\n`
        + `  static func fromJSON(optionalJSON: JSON?) -> ${object.name}? {\n`
        + `    return optionalJSON.string.flatMap { ${object.name}(rawValue: $0.lowercaseString }\n`
        + '  }\n\n'
        + `  func toJSON() -> JSON {\n`
        + `    return JSON(self.rawValue.lowercaseString)\n`
        + '  }\n\n'
        + '}\n'
    } else {

      return `extension ${object.name} : JSONEncodable {\n\n`
        + `  static func fromJSON(optionalJSON: JSON?) -> ${object.name}? {\n`
        + '    guard let json = optionalJSON,\n'
        + object.fields.map(function(field) {
           if (field.type === 'String' || field.type === 'Bool') {
             return `      ${field.name} = json["${field.name}"].${field.type.toLowerCase()}`
           } else {
             return `      ${field.name} = ${field.type}.fromJSON(json["${field.name}"])`
           }
        }).join(',\n')
        + '      else {\n'
        + '        return nil\n'
        + '      }\n\n'
        + `  return ${constructorCall(object)}\n`
        + '  }\n'
        + `  func toJSON() -> JSON {`
        + '    var json = JSON([:])'
        + object.fields.map(function(field) {
           if (field.type === 'String' || field.type === 'Bool') {
             return `      json["${field.name}"] = JSON(self.${field.name})`
           } else {
             return `      json["${field.name}"] = ${field.name}.toJSON()`
           }
        }).join('\n')
        + '        return json\n'
        + '  }\n'
        + '}\n'
    }
  }).join('\n\n')


function constructorCall(object) {
    return object.name
    + '('
    + object.fields.map(function(field) { return `${field.name}: ${field.name}` }).join(',')
    + ')'
}
