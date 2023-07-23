package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"reflect"
	"sort"
	"strings"
	"sync"

	"github.com/abrander/colorjson" // "encoding/json"
	// "fmt"
	// "log"
	// "os"
	// "os/exec"
	// "reflect"
	// "strings"
	c "sentencer/gsentencer/lib"
	// "github.com/abrander/colorjson"
)

func main() {
	conf := c.FetchConfig()

	contentPath := conf.Directory + string(os.PathSeparator) + conf.Input
	data, err := os.ReadFile(contentPath)
	if err != nil {
		log.Fatal(err)
	}

	// data := "Niños desaparecidos en la selva de Colombia"
	datos := lines(string(data))
	// fmt.Println(len(datos))
	trans := mapConcurrently(datos, translate)
	res := flatArrays(trans)

	// fmt.Println(str)

	// jsonString := normalizer(string(dump))

	// fmt.Println(jsonString)
	// var result []any

	// errJ := json.Unmarshal([]byte(jsonString), &result)
	// if err != nil {
	// 	fmt.Printf("could not unmarshal json: %s\n", errJ)
	// 	return
	// }
	// fmt.Println(result)

	// rawJson := unpackArray(jsonArr[0])
	// var res [][]string
	// for _, val := range rawJson {
	// 	r := unpackArray(val)
	// 	if r[0] != nil && r[1] != nil {
	// 		var v []string
	// 		v = append(v, r[1].(string), r[0].(string))
	// 		res = append(res, v)
	// 	}
	// }

	// // fmt.Println(res)

	flatten := []byte(res)

	// // fmt.Println(flatten)

	writePath := makePath(conf)

	errW := os.WriteFile(writePath, flatten, 0666)

	if err != nil {
		log.Fatal(errW)
	}
}

func translate(source string) []string {
	dump := runEsRu(source)
	dumpNormal := normalizer(dump)
	var jsonArr []any
	errJ := json.Unmarshal([]byte(dumpNormal), &jsonArr)
	if errJ != nil {
		fmt.Printf("could not unmarshal json: %s\n", errJ)
	}
	rawJson := unpackArray(jsonArr[0])
	var res []string
	fmt.Println(rawJson)

	r := unpackArray(rawJson[0])
	if r[0] != nil && r[1] != nil {
		res = append(res, r[1].(string), r[0].(string))
	}
	return res
}

func runEsRu(source string) string {
	cmd := exec.Command("trans", "es:ru", "-dump", source)
	stdout, err := cmd.Output()

	if err != nil {
		fmt.Println(err.Error())
	}
	return string(stdout)
}

func normalizer(dirty string) string {
	firstPosition := strings.Index(dirty, "[")
	lastPosition := strings.LastIndex(dirty, "]")
	return dirty[firstPosition : lastPosition+1]
}

func unpackArray(s any) []any {
	v := reflect.ValueOf(s)
	r := make([]any, v.Len())
	for i := 0; i < v.Len(); i++ {
		r[i] = v.Index(i).Interface()
	}
	return r
}

func prettyJson(a any) (b any) {
	encoder := colorjson.NewEncoder(os.Stdout, colorjson.Default)
	return encoder.Encode(a)
}

func flatArrays(arrs [][]string) string {
	var res []string
	for _, val := range arrs {
		// strings.Join(val, ", ")
		res = append(res, strings.Join(val, "\n"))
	}
	return strings.Join(res, "\n\n")
}

type target func(string) []string
type Pair struct {
	Key   int
	Trans []string
}

func mapConcurrently(input []string, fn target) [][]string {
	var (
		wg       sync.WaitGroup
		resultCh = make(chan Pair, len(input))
	)
	for k, item := range input {
		wg.Add(1)
		go func(item string, k int) {
			defer wg.Done()
			resultCh <- Pair{k, fn(item)}
		}(item, k)
	}

	go func() {
		wg.Wait()
		close(resultCh)
	}()

	var sortedPair []Pair
	for p := range resultCh {
		sortedPair = append(sortedPair, p)
	}
	sort.Slice(sortedPair, func(i, j int) bool {
		return sortedPair[i].Key < sortedPair[j].Key
	})
	// fmt.Println(sortedPair)
	var result [][]string
	for _, p := range sortedPair {
		result = append(result, p.Trans)
	}

	return result
}

func lines(str string) []string {
	str = strings.Trim(str, " .\n\r\t")
	list := strings.Split(str, ".")
	var newList []string
	for _, v := range list {
		v = strings.Trim(v, " \n\r\t")
		newList = append(newList, v)
	}

	return newList
}

func makePath(conf c.Config) string {
	end := strings.Split(conf.Input, "_")[1]
	return conf.Directory + string(os.PathSeparator) + "go_result_" + end
}
