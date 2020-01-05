using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

namespace net.derammo.HelBIOS
{
    public class DcsBiosEnumConverterFactory : JsonConverterFactory
    {
        private static readonly HashSet<string> _reservedWords = new HashSet<string>()
        {
            "interface",
            "string"
        };

        public override bool CanConvert(Type typeToConvert)
        {
            return typeToConvert.IsEnum;
        }

        public override JsonConverter CreateConverter(
            Type type,
            JsonSerializerOptions options)
        {
            JsonConverter converter = (JsonConverter)Activator.CreateInstance(
                typeof(DcsBiosEnumConverter<>).MakeGenericType(
                    new Type[] { type }),
                BindingFlags.Instance | BindingFlags.Public,
                binder: null,
                args: new object[] { options },
                culture: null);
            return converter;
        }

        private class DcsBiosEnumConverter<TEnum> :
            JsonConverter<TEnum> where TEnum : struct, Enum
        {
            public DcsBiosEnumConverter(JsonSerializerOptions options)
            {
            }

            private static readonly Regex startsIllegal = new Regex("^[^a-zA-Z]");

            public override TEnum Read(
                ref Utf8JsonReader reader,
                Type typeToConvert,
                JsonSerializerOptions options)
            {
                if (reader.TokenType != JsonTokenType.String)
                {
                    throw new JsonException();
                }

                string stringValue = reader.GetString();

                // now clean it
                if (startsIllegal.IsMatch(stringValue) || _reservedWords.Contains(stringValue))
                {
                    stringValue = $"_{stringValue}";
                }
                stringValue = stringValue.Replace(" ", "_");

                // For performance, parse with ignoreCase:false first.
                if (!Enum.TryParse(stringValue, ignoreCase: false, out TEnum key) &&
                    !Enum.TryParse(stringValue, ignoreCase: true, out key))
                {
                    throw new JsonException(
                        $"Unable to convert \"{stringValue}\" to Enum \"{typeToConvert}\".");
                }
                return key;
            }

            public override void Write(
                Utf8JsonWriter writer,
                TEnum value,
                JsonSerializerOptions options)
            {
                throw new NotImplementedException();
            }
        }
    }
}