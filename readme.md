This software is unofficial and is not related in any way to Lidl or Grocy. It is using [lidl-plus](https://github.com/Andre0512/lidl-plus) requests and can stop working at anytime!

# lidltogrocy

An command line executable to add easily your Lidl receipts into [Grocy](https://github.com/grocy/grocy).

## Key Features

* Run Lidl-Plus python script to get lidl receipts (json)
* Check each items in Grocy
	* If it doens't exists, will call OpenFoodFacts to get some infos (name and image), will create the product in Grocy (adding barcode for it) and will adding the given quantity
	* If it exists, will adding the given quantity
* Consumes immediately products after adding it in Grocy (useful for massively inserting old receipts and keep prices)
* Do not add quantities in stock (useful for massively inserting old receipts and DON'T keep prices)

## Usage

* Install [lidl-plus](https://github.com/Andre0512/lidl-plus) using Pip
* Fill settings.json
* Run LidlToGrocy executable with grocy and lidl-plus params

```bash                                                                        
Usage: lidltogrocy [options] [params]

Options:
  /v, /verbose        generate verbose output
  /?, /help           display this message
  /n, /no-add-stock   don't add product in stock
  /c, /no-call-openfoodfacts
                      don't get product infos from openfoodfacts
  /s, /save-lidl-json save lidl json in a file (lidl.json)
  /o, /consume-now    consume grocy product after adding

Params:
  /i, /grocy-ip <value>
                      grocy ip address
  /p, /grocy-port <value> (default 9283)
                      grocy port
  /a, /grocy-apikey <value>
                      grocy api key
  /c, /lidl-country <value> (default EN)
                      lidl country
  /l, /lidl-lang <value> (default en)
                      lidl language
  /t, /lidl-token <value>
                      lidl token (see https://github.com/Andre0512/lidl-plus#commandline-tool)
  /f, /lidl-filepath <value>
                      lidl json file (optional)
```