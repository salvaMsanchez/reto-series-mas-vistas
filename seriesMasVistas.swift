import Foundation

struct Serie {
	let nombre: String
	var minutos: Int
}

enum FormatosStringSerie {
	case correcto
	case ceroFinPrograma
}

final class RetoSeries {

	// Atributos
	//---
	private var listaSeries: [Serie] = []
	private var diccionarioSeries: [Int:[Serie]]
	private var diccionarioSeriesOrdenado: [Int:[Serie]]
	private var numCaso: Int = 1

	// Inicializador
	//---
	init(diccionarioSeries: [Int:[Serie]], diccionarioSeriesOrdenado: [Int:[Serie]]) {
		self.diccionarioSeries = diccionarioSeries
		self.diccionarioSeriesOrdenado = diccionarioSeriesOrdenado
	}

	// Métodos
	//---

	// Método público que ejecuta la lógica principal corroborando si el formato es correcto o no mediante el enum definido anteriormente
	func caso() {
		var finalPrograma: FormatosStringSerie = .correcto
		while finalPrograma == .correcto {
			finalPrograma = casosDescritos(lecturaNumeroCasos())
		}
		printSalida()
	}

	// Método encargado de leer la entrada del usuario respecto al número de series que quiere introducir por teclado
	private func lecturaNumeroCasos() -> Int {

		while true {
			if let numCasosString: String = readLine(),
			let numCasos = Int(numCasosString) {
				if numCasos > 0,
				numCasos < 1_000 {
				    return numCasos
				} else if numCasos == 0 {
					return 0
				} else {
					print("Error en el formato (se ha introducido un número negativo o mayor o igual a 1000). Introduce un número entero entre 1 y 1000, el cual representará las veces que has visto una serie.")
				}
			} else {
				print("Error en el formato (se ha introducido texto o número decimal). Introduce un número entero entre 1 y 1000, el cual representará las series que has visto.")
			}
			
		}

	}

	// Método que se ocupa de la lectura de la línea donde se han escrito los minutos vistos y el nombre de la serie, los cuales se
	// devuelven como tupla
	private func lecturaSerie() -> (serie: String, minutos: Int) {

		while true {
			if let entrada: String = readLine(),
			entrada.count < 104, 
			let minutos: Int = Int(entrada.components(separatedBy: " ")[0]),
			minutos <= 200,
			minutos > 0 {
				let entradaDivididaPorEspacios: [String] = entrada.components(separatedBy: " ")
				var serieSucia: String = ""
				for indice in 1..<entradaDivididaPorEspacios.count {
					serieSucia = serieSucia + entradaDivididaPorEspacios[indice] + " "
				}
				let serie: String = serieSucia.trimmingCharacters(in: .whitespaces)
				return (serie, minutos)
			} else {
				print("Error en el formato. Longitud de caracteres excedida, no se han introducido los minutos de la serie (máximo 200 minutos) o se ha introducido un número decimal.")
			}
		}
		
	}

	// Método que comprueba si hay una serie ya almacenada en nuestro diccionario. En caso afirmativo, se añaden los minutos vistos; 
	// por eso, se pasa la variable serie por referencia, para que pueda ser modificada
	private func comprobarRepeticionSerie(_ serie: inout Serie) -> Bool {
		for (indice, serieLista) in listaSeries.enumerated() {
			if serie.nombre == serieLista.nombre {
				let guardarMinutosDeSerieEliminada: Int = serieLista.minutos
				eliminarSerieRepetida(indice)
				serie.minutos = serie.minutos + guardarMinutosDeSerieEliminada
				listaSeries.append(serie)

				return true
			} else {
				return false
			}
		}
		return false
	}

	// Método que se encarga de eliminar una serie repetida en pos de añadir, a continuación, la misma serie
	// pero con los minutos actualizados
	private func eliminarSerieRepetida(_ indice: Int) {
		listaSeries.remove(at: indice)
	}

	// Método que se ocupa de ordenar en un nuevo diccionario (el cual será el usado a partir de la ejecución de este método)
	// atendiendo a los condicionantes del enunciado: orden por minutos o, en caso de empate, por orden alfabético
	private func ordenacion() { 
		for (key, value) in diccionarioSeries {
			var arraySeries: [Serie] = value
			arraySeries.sort {
				$0.nombre < $1.nombre
			}
			arraySeries.sort {
				$0.minutos > $1.minutos
			}

			diccionarioSeriesOrdenado[key] = arraySeries

		}
	}
	
	// Método que se encarga de consultar el diccionario que almacena toda la información y de imprimir en consola,
	// como máximo, las 3 series más vistas
	private func printSalida() -> Void {

		ordenacion()

		// Tener array ordenado con las keys del dict (nombres de las series) para imprimir por pantalla los casos ordenados
		// según introducción del usuario
		var keysTotales: [Int] = []
		for (key, _) in diccionarioSeriesOrdenado {
			keysTotales.append(key)
		}
		keysTotales.sort() {
			$0 < $1
		}

		// Impresión de los 3 series más vistas
		for key in keysTotales {
			if let series = diccionarioSeriesOrdenado[key] {
				if series.count <= 3 {
					for serie in series {
						print(serie.nombre)
					}
				} else {
					var contador: Int = 0
					for serie in series {
						if contador > 2 {
							break
						} else {
							print(serie.nombre)
							contador = contador + 1
						}
					}
				}
			}
			print("---")
		}
		
	}

	// Eliminar series menos vistas (por debajo de 30 minutos)
	private func eliminarSeriesMenosVistas() {
		for (indice, serie) in listaSeries.enumerated() {
			if serie.minutos < 30 {
				listaSeries.remove(at: indice)
			}
		}
		diccionarioSeries[self.numCaso] = listaSeries
	}

	// Método que refleja la estructura general del programa y que se encarga de organizar y llamar a la 
	// gran mayoría de métodos desarrollados
	private func casosDescritos(_ numSeries: Int) -> FormatosStringSerie {

		if numSeries != 0 {

			for _ in 0..<numSeries {

				let serieMinutos = lecturaSerie()
				var serie: Serie = Serie(nombre: serieMinutos.serie, minutos: serieMinutos.minutos)

				var indiceEncontradoSerieRepetida: Int? = nil

				// Buscar la serie en la lista y guardar su índice si se encuentra
				for (indice, serieLista) in listaSeries.enumerated() {
				    if serie.nombre == serieLista.nombre {
				        indiceEncontradoSerieRepetida = indice
				        break
				    }
				}

				// Si se encontró la serie, fusionarla y eliminarla de la lista
				if let index = indiceEncontradoSerieRepetida {
				    let guardarMinutosDeSerieEliminada: Int = listaSeries[index].minutos
				    listaSeries.remove(at: index)
				    serie.minutos += guardarMinutosDeSerieEliminada
				}

				// Agregar la serie fusionada (si es nueva) o reemplazada a la lista
				listaSeries.append(serie)

			}

			eliminarSeriesMenosVistas()

			listaSeries = []
			self.numCaso += 1
			return .correcto

		} else {
			return .ceroFinPrograma
		}

	}

}

// Main
var diccionarioSeries: [Int:[Serie]] = [Int:[Serie]]()
var diccionarioSeriesOrdenado: [Int:[Serie]] = [Int:[Serie]]()
let retoSeries: RetoSeries = RetoSeries(diccionarioSeries: diccionarioSeries, diccionarioSeriesOrdenado: diccionarioSeriesOrdenado)
retoSeries.caso()
