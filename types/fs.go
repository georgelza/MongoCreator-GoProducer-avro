package types

// Structs - the values we bring in from *app.json configuration file
type TPGeneral struct {
	EchoConfig        int
	Hostname          string
	Debuglevel        int
	Testsize          int     // Used to limit number of records posted, over rided when reading test cases from input_source,
	Sleep             int     // sleep time between Basket payload Create and Payment payload create
	SeedFile          string  // Which seed file to read in
	EchoSeed          int     // 0/1 Echo the seed data to terminal
	CurrentPath       string  // current
	OSName            string  // OS name
	Vatrate           float64 // Amount
	Store             int     // if <> 0 then store at that position in array is selected.
	Terminals         int     // Number of possible checkout points/terminals
	KafkaEnabled      int     // if = 1 then post docs to kafka
	MongoAtlasEnabled int     // if = 1 then post docs to MongoDB
	Json_to_file      int     // do we spool the created baskets and payments to a file/s
	Output_path       string  // if yes above then pipe json here. we will spool the baskets to one file and the payments to a second.
	TimeOffset        string  // what offset do we run with, from GMT / Zulu time
	Max_items_basket  int     // max items in a basket
	Max_quantity      int     // max quantity of items in a basket per product
	KafkaConfigFile   string  // Kafka configuration file
	MongoConfigFile   string  // Mongo configuration file
}

type TPKafka struct {
	EchoConfig        int
	Bootstrapservers  string
	SchemaRegistryURL string
	BasketTopicname   string
	PaymentTopicname  string
	Numpartitions     int
	Replicationfactor int
	Retension         string
	Parseduration     string
	Security_protocol string
	Sasl_mechanisms   string
	Sasl_username     string
	Sasl_password     string
	Flush_interval    int
}

type TPMongodb struct {
	Url               string
	Uri               string
	Root              string
	Port              string
	Username          string
	Password          string
	Datastore         string
	Basketcollection  string
	Paymentcollection string
	Batch_size        int
}

type TPBasketItems struct {
	Id       string  `json:"id,omitempty"`
	Name     string  `json:"name,omitempty"`
	Brand    string  `json:"brand,omitempty"`
	Category string  `json:"category,omitempty"`
	Price    float64 `json:"price,omitempty"`
	Quantity int     `json:"quantity,omitempty"`
}

type TPBasket struct {
	InvoiceNumber      string          `json:"invoiceNumber,omitempty" avro:"invoiceNumber"`
	SaleDateTime_Ltz   string          `json:"saleDateTime_Ltz,omitempty" avro:"saleDateTime_Ltz"`
	SaleTimestamp_Epoc string          `json:"saleTimestamp_Epoc,omitempty" avro:"saleTimestamp_Epoc"`
	TerminalPoint      string          `json:"terminalPoint,omitempty" avro:"terminalPoint"`
	Nett               float64         `json:"nett,omitempty" avro:"nett"`
	Vat                float64         `json:"vat,omitempty" avro:"vat"`
	Total              float64         `json:"total,omitempty" avro:"total"`
	Store              TPIDStruct      `json:"store,omitempty" avro:"store"`
	Clerk              TPIDStruct      `json:"clerk,omitempty" avro:"clerk"`
	BasketItems        []TPBasketItems `json:"basketItems,omitempty" avro:"basketItems"`
}

type TPPayment struct {
	InvoiceNumber     string  `json:"invoiceNumber,omitempty" avro:"invoiceNumber"`
	PayDateTime_Ltz   string  `json:"payDateTime_Ltz,omitempty" avro:"payDateTime_Ltz"`
	PayTimestamp_Epoc string  `json:"payTimestamp_Epoc,omitempty" avro:"payTimestamp_Epoc"`
	Paid              float64 `json:"paid,omitempty" avro:"paid"`
	FinTransactionID  string  `json:"finTransactionId,omitempty" avro:"finTransactionId"`
}

// the below is used as structure of the seed file
type TPIDStruct struct {
	Id   string `json:"id,omitempty" avro:"id"`
	Name string `json:"name,omitempty" avro:"name"`
}

type TProductStruct struct {
	Id       string  `json:"id,omitempty"`
	Name     string  `json:"name,omitempty"`
	Brand    string  `json:"brand,omitempty"`
	Category string  `json:"category,omitempty"`
	Price    float64 `json:"price,omitempty"`
}

type TPSeed struct {
	Clerks   []TPIDStruct     `json:"clerks,omitempty"`
	Stores   []TPIDStruct     `json:"stores,omitempty"`
	Products []TProductStruct `json:"products,omitempty"`
}
