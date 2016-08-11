

return '// MARK: - JSONEncodable\n\n'
  + extensions.AutoJSONEncodable.map(function(object) {

    if (object.isEnum) {

      if (object.extensions.includes("String") || object.extensions.includes("Int")) {
        return rawValueBackedEnumJSONCodec(object)
      } else {
        return enumJSONCodec(object)
      }
    } else {
      return structJSONCodec(object)

    }
  }).join('\n\n')




function enumJSONCodec(object) {
  return `extension ${object.name} : JSONEncodable {\n\n`
    + '  private var typeString: String {\n'
    + '    switch self {\n'
    + object.enumCases.map(function(enumCase) {
      return `    case .${enumCase.name}:  return "${enumCase.name.toLowerCase()}"`
    }).join('\n')
    + '     }\n'
    + '  }\n\n'
    + `  static func fromJSON(optionalJSON: JSON?) -> ${object.name}? {\n`
    + '    guard let json = optionalJSON,\n'
    + '      type = json["type"].string,\n'
    + '      values = json["values"].array\n'
    + '      else {\n'
    + '        return nil\n'
    + '      }\n\n'
    + `    switch (type) {\n`
    + object.enumCases.map(function(enumCase) {
      return `      case "${enumCase.name.toLowerCase()}":\n`
        + `      return ${enumAssociatedValuesConstructor(enumCase)}`
    }).join('\n')
    + '    }\n'
    + '  }\n\n'
    + `  func toJSON() -> JSON {`
    + '    var json = JSON([:])'
    + '    json["type"] = JSON(self.typeString)'
    + '    switch self {\n'
    + object.enumCases.map(function(enumCase) {
      return `      case .${enumCase.name}${listEnumAssociatedValues(enumCase)}:\n`
        + `      json["values"] = JSON(${enumAssociatedValuesExporter(enumCase)})\n`
    }).join('\n')
    + '    }\n'
    + '    return json\n'
    + '  }\n'
    + '}\n'
}

function enumAssociatedValuesExporter(enumCase) {
  return '['
    + enumCase.associatedValues.map(function(associatedValue, index) {
      if (isSwiftPrimitive(associatedValue)) {
        return `JSON(value${index + 1})`
      } else {
        return `value${index + 1}.toJSON()`
      }
    }).join(', ')
    + ']'
}

function listEnumAssociatedValues(enumCase) {
  if (enumCase.associatedValues != undefined && enumCase.associatedValues != null && enumCase.associatedValues.length > 0) {
    return '('
      + enumCase.associatedValues.map(function (associatedValue, index) {
          return `let value${index+1}`
        }).join(', ')
      + ')'
  } else {
    return ''
  }
}

function enumAssociatedValuesConstructor(enumCase) {
  if (enumCase.associatedValues != undefined && enumCase.associatedValues != null && enumCase.associatedValues.length > 0) {
    return `.${enumCase.name}(`
      + enumCase.associatedValues.map(function(associatedValue, index) {
        if (isSwiftPrimitive(associatedValue)) {
          return `values[${index}].${associatedValue.toLowerCase()}`
        } else {
          return `${associatedValue}.fromJSON(values[${index}])`
        }
      }).join(', ')
      + ')'
  } else {
    return `.${enumCase.name}`
  }
}


function rawValueBackedEnumJSONCodec(object) {
  return `extension ${object.name} : JSONEncodable {\n\n`
    + `  static func fromJSON(optionalJSON: JSON?) -> ${object.name}? {\n`
    + `    return optionalJSON.string.flatMap { ${object.name}(rawValue: $0.lowercaseString }\n`
    + '  }\n\n'
    + `  func toJSON() -> JSON {\n`
    + `    return JSON(self.rawValue.lowercaseString)\n`
    + '  }\n\n'
    + '}\n'
}



function structJSONCodec(object) {
  return `extension ${object.name} : JSONEncodable {\n\n`
    + `  static func fromJSON(optionalJSON: JSON?) -> ${object.name}? {\n`
    + '    guard let json = optionalJSON,\n'
    + object.fields.map(function(field) {
       if (isSwiftPrimitive(field.type)) {
         return `      ${field.name} = json["${field.name}"].${field.type.toLowerCase()}`
       } else {
         return `      ${field.name} = ${field.type}.fromJSON(json["${field.name}"])`
       }
    }).join(',\n')
    + '      else {\n'
    + '        return nil\n'
    + '      }\n\n'
    + `  return ${structConstructor(object)}\n`
    + '  }\n'
    + `  func toJSON() -> JSON {`
    + '    var json = JSON([:])'
    + object.fields.map(function(field) {
      if (isSwiftPrimitive(field.type)) {
         return `      json["${field.name}"] = JSON(self.${field.name})`
       } else {
         return `      json["${field.name}"] = ${field.name}.toJSON()`
       }
    }).join('\n')
    + '        return json\n'
    + '  }\n'
    + '}\n'
}

function structConstructor(object) {
    return object.name
    + '('
    + object.fields.map(function(field) { return `${field.name}: ${field.name}` }).join(',')
    + ')'
}

function isSwiftPrimitive(type) {
  return (type === 'String' || type === 'Bool' || type === 'Int')
}
