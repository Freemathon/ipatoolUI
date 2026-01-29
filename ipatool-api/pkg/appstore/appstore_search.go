package appstore

import (
	"errors"
	"fmt"
	gohttp "net/http"
	"net/url"
	"strconv"
	"strings"

	"github.com/majd/ipatool/v2/pkg/http"
)

type SearchInput struct {
	Account     Account
	Term        string
	Limit       int64
	CountryCode string // Optional: if specified, use this country code instead of account's storefront
}

type SearchOutput struct {
	Count   int
	Results []App
}

func (t *appstore) Search(input SearchInput) (SearchOutput, error) {
	var countryCode string
	var err error

	// Use specified country code if provided, otherwise use account's storefront
	if input.CountryCode != "" {
		// Validate country code exists in storeFronts
		if _, exists := storeFronts[strings.ToUpper(input.CountryCode)]; !exists {
			return SearchOutput{}, fmt.Errorf("invalid country code: %s", input.CountryCode)
		}
		countryCode = strings.ToUpper(input.CountryCode)
	} else {
		countryCode, err = countryCodeFromStoreFront(input.Account.StoreFront)
		if err != nil {
			return SearchOutput{}, fmt.Errorf("country code is invalid: %w", err)
		}
	}

	request := t.searchRequest(input.Term, countryCode, input.Limit)

	res, err := t.searchClient.Send(request)
	if err != nil {
		return SearchOutput{}, fmt.Errorf("request failed: %w", err)
	}

	if res.StatusCode != gohttp.StatusOK {
		return SearchOutput{}, NewErrorWithMetadata(errors.New("request failed"), res)
	}

	return SearchOutput{
		Count:   res.Data.Count,
		Results: res.Data.Results,
	}, nil
}

type searchResult struct {
	Count   int   `json:"resultCount,omitempty"`
	Results []App `json:"results,omitempty"`
}

func (t *appstore) searchRequest(term, countryCode string, limit int64) http.Request {
	return http.Request{
		URL:            t.searchURL(term, countryCode, limit),
		Method:         http.MethodGET,
		ResponseFormat: http.ResponseFormatJSON,
	}
}

func (t *appstore) searchURL(term, countryCode string, limit int64) string {
	params := url.Values{}
	params.Add("entity", "software,iPadSoftware")
	params.Add("limit", strconv.Itoa(int(limit)))
	params.Add("media", "software")
	params.Add("term", term)
	params.Add("country", countryCode)

	return fmt.Sprintf("https://%s%s?%s", iTunesAPIDomain, iTunesAPIPathSearch, params.Encode())
}
