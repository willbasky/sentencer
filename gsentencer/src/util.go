package util

import (
	"encoding/json"
	"log"
	"os"
	"os/exec"
	"reflect"
	"strings"
)

type ListOfPairs [][2]string

func MakePath(conf Config) string {
	end := strings.Split(conf.Input, "_")[1]
	return conf.Directory + string(os.PathSeparator) + "go_result_" + end
}

func Lines(str string) []string {
	trimControl := " \n\t\r"
	str = strings.Trim(str, trimControl)
	list := strings.Split(str, "\n")
	var nonEmpty []string
	for _, r := range list {
		if r != "" {
			nonEmpty = append(nonEmpty, r)
		}
	}
	return nonEmpty
}

func Normalizer(dirty string) string {
	firstPosition := strings.Index(dirty, "[")
	lastPosition := strings.LastIndex(dirty, "]")
	return dirty[firstPosition : lastPosition+1]
}

func PrettyJson(js any) string {
	marshaled, err := json.MarshalIndent(js, "", "   ")
	if err != nil {
		log.Fatalf("marshaling error: %s", err)
	}
	return string(marshaled)
}

// [[["qwe","qwe"],["zxc","cvx"]],[["dfg","yuyt"],["hj","ghjgh"]]]
// [[["qwe\nqwe"],["zxc\ncvx"]],[["dfg\nyuyt"],["hj\nghjgh"]]]
func FlatArrays(arrs []ListOfPairs) string {
	var concatPair []string
	for _, listPair := range arrs {
		for _, pair := range listPair {
			concatPair = append(concatPair, strings.Join(pair[:], "\n"))
		}
	}
	return strings.Join(concatPair, "\n\n")
}

func RunEsRu(source string) string {
	cmd := exec.Command("trans", "es:ru", "-dump", source)
	stdout, err := cmd.Output()
	if err != nil {
		log.Println(err.Error())
	}
	return string(stdout)
}

func UnpackArray(s interface{}) []interface{} {
	v := reflect.ValueOf(s)

	if v.Kind() != reflect.Slice {
		log.Println("unpackArray:", "is not array", "but it is", v)
		return nil
	}

	r := make([]interface{}, v.Len())
	for i := 0; i < v.Len(); i++ {
		r[i] = v.Index(i).Interface()
	}
	return r
}
