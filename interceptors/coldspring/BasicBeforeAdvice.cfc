component output="false" {


	function before(method,args,target){

		ArrayAppend(request.callstack, "before");
		arguments.args.input = "before" & arguments.args.input;
	}
}