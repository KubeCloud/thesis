@HystrixCommand(fallbackMethod = "open", commandKey = "resources")
@RequestMapping(value = "/resources")
public ResponseEntity<List<Resource>> resources() {

    IService2 service2 = Feign.builder()
            .decoder(new JacksonDecoder())
            .target(IService2.class, "http://"+service2host+":"+service2port);

    List<Resource> resources = service2.resources();

    return new ResponseEntity<List<Resource>>(resources, HttpStatus.OK);
}

public ResponseEntity<List<Resource>> open(){
    return new ResponseEntity<>(state.getResources().subList(0, state.getAmount()), HttpStatus.PARTIAL_CONTENT);
}