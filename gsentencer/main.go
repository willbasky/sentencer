package main

import (
	"encoding/json"
	"log"
	"os"
	"sort"
	"sync"

	src "sentencer/gsentencer/src"
)

func main() {
	conf := src.FetchConfig()

	contentPath := conf.Directory + string(os.PathSeparator) + conf.Input
	data, err := os.ReadFile(contentPath)
	if err != nil {
		log.Fatal(err)
	}

	datos := src.Lines(string(data))

	trans := mapConcurrently(datos, translate)

	res := src.FlatArrays(trans)

	flatten := []byte(res)

	writePath := src.MakePath(conf)

	errW := os.WriteFile(writePath, flatten, 0666)
	if errW != nil {
		log.Fatal(errW)
	}
}

func translate(source string) src.ListOfPairs {
	dump := src.RunEsRu(source)
	dumpNormal := src.Normalizer(dump)

	var jsonArrFull []any
	err := json.Unmarshal([]byte(dumpNormal), &jsonArrFull)
	if err != nil {
		log.Printf("could not unmarshal json: %s\n", err)
		return nil
	}

	jsonArrMedium := src.UnpackArray(jsonArrFull[0])
	if jsonArrMedium == nil {
		log.Printf("could not unpackArray jsonArrFull: %s\n", err)
		return nil
	}

	var res src.ListOfPairs
	for _, jsonArrCore := range jsonArrMedium {
		core := src.UnpackArray(jsonArrCore)
		if core == nil {
			log.Printf("could not unpackArray jsonArrCore: %s\n", err)
			return nil
		}
		if core[0] != nil && core[1] != nil {
			var pair [2]string
			pair[0] = core[1].(string)
			pair[1] = core[0].(string)
			res = append(res, pair)
		}
	}
	return res
}

type target func(string) src.ListOfPairs
type Pair struct {
	Key   int
	Trans src.ListOfPairs
}

func mapConcurrently(input []string, fn target) []src.ListOfPairs {
	var (
		wg       sync.WaitGroup
		resultCh = make(chan Pair, len(input))
	)
	for k, item := range input {
		wg.Add(1)
		go func(item string, k int) {
			defer wg.Done()
			res := fn(item)
			if res != nil {
				resultCh <- Pair{k, res}
			}
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
	var result []src.ListOfPairs
	for _, p := range sortedPair {
		result = append(result, p.Trans)
	}

	return result
}
