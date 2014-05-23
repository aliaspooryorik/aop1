component extends="mxunit.framework.TestCase"{


	function TestBeforeAroundAfterInterception(){

			//Putting it all together What happens when you call all of them?
			request.callstack = []; //reset
			bf = new aop('/services,/interceptors', {});
			//add an Interceptor

			bf.intercept("ReverseService", "BeforeInterceptor");
			bf.intercept("ReverseService", "AroundInterceptor");
			bf.intercept("ReverseService", "AfterInterceptor");

			rs = bf.getBean("ReverseService");
			result = rs.doReverse("Hello!");


			AssertEquals(result, Reverse("Hello!"));
			AssertEquals(ArrayLen(request.callstack),2);
			AssertEquals(ArrayToList(request.callstack),"around,doReverse");

	}

	function TestMultipleBeforeInterceptions(){
		//Multiple Before Advisors
		request.callstack = []; //reset
		bf = new aop('/services,/interceptors', {});
		//Need to create different Before interceptors

		bf.addBean("BeforeInterceptorA", new interceptors.aop.BeforeInterceptor("beforeA"));
		bf.addBean("BeforeInterceptorB", new interceptors.aop.BeforeInterceptor("beforeB"));
		bf.addBean("BeforeInterceptorC", new interceptors.aop.BeforeInterceptor("beforeC"));
		bf.intercept("ReverseService", "BeforeInterceptorA");
		bf.intercept("ReverseService", "BeforeInterceptorB");
		bf.intercept("ReverseService", "BeforeInterceptorC");

		rs = bf.getBean("ReverseService");
		result = rs.doReverse("Hello!");

		AssertEquals(result, Reverse("beforebeforebeforeHello!"));
		AssertEquals(ArrayLen(request.callstack),4);
		AssertEquals(ArrayToList(request.callstack),"beforeA,beforeB,beforeC,doReverse");

	}

	function TestMiltipleAfterInterceptors(){
		//Multiple After Advisors
		request.callstack = []; //reset
		bf = new aop('/services,/interceptors', {});
		//Need to create different Before interceptors

		bf.addBean("AfterInterceptorA", new interceptors.aop.AfterInterceptor("afterA"));
		bf.addBean("AfterInterceptorB", new interceptors.aop.AfterInterceptor("afterB"));
		bf.addBean("AfterInterceptorC", new interceptors.aop.AfterInterceptor("afterC"));
		bf.intercept("ReverseService", "AfterInterceptorA");
		bf.intercept("ReverseService", "AfterInterceptorB");
		bf.intercept("ReverseService", "AfterInterceptorC");
		rs = bf.getBean("ReverseService");
		result = rs.doReverse("Hello!");

		AssertEquals(result, Reverse("Hello!"));
		AssertEquals(ArrayLen(request.callstack),4);
		AssertEquals(ArrayToList(request.callstack),"doReverse,afterA,afterB,afterC");
	}

	function TestMultipleAroundInterceptors(){

		//Multiple Around Advisors
		request.callstack = []; //reset
		bf = new aop('/services,/interceptors', {});
		//Need to create different Before interceptors

		bf.addBean("AroundInterceptorA", new interceptors.aop.AroundInterceptor("aroundA"));
		bf.addBean("AroundInterceptorB", new interceptors.aop.AroundInterceptor("aroundB"));
		bf.addBean("AroundInterceptorC", new interceptors.aop.AroundInterceptor("aroundC"));
		bf.intercept("ReverseService", "AroundInterceptorA");
		bf.intercept("ReverseService", "AroundInterceptorB");
		bf.intercept("ReverseService", "AroundInterceptorC");
		rs = bf.getBean("ReverseService");

		result = rs.doReverse("Hello!");

		AssertEquals(result, Reverse("Hello!"));
		AssertEquals(ArrayLen(request.callstack),4);
		AssertEquals(ArrayToList(request.callstack),"aroundA,aroundB,aroundC,doReverse");

	}

	function TestNamedMethodInterceptions(){

		//Named Method Interceptions

		request.callstack = []; //reset
		bf = new aop('/services,/interceptors', {});
		//add an Interceptor
		bf.intercept("ReverseService", "BeforeInterceptor", "doReverse");

		rs = bf.getBean("ReverseService");

		AssertEquals(rs.methodMatches("doForward", "doReverse"), false);
		AssertEquals(rs.methodMatches("doForward", ""), true);
		AssertEquals(rs.methodMatches("doForward", "doReverse,"), false);
		AssertEquals(rs.methodMatches("doForward", "doReverse,doForward"), true);


		result = rs.doReverse("Hello!");

		AssertEquals(result, Reverse("beforeHello!"));
		AssertEquals(ArrayLen(request.callstack),2);
		AssertEquals(ArrayToList(request.callstack),"before,doReverse");

	}


	public function TestOnErrorInterceptors() {

		request.callstack = []; //reset
		bf = new aop('/services,/interceptors', {});
		//add an Interceptor
		bf.intercept("ReverseService", "ErrorInterceptor", "throwError");

		rs = bf.getBean("ReverseService");

		result2 = rs.doForward("Hello!");


		AssertEquals(result2, "Hello!");
		AssertEquals(ArrayLen(request.callstack),1);
		AssertEquals(ArrayToList(request.callstack),"doForward");

		request.callstack = []; //reset
		bf = new aop('/services,/interceptors', {});
		//add an Interceptor
		bf.intercept("ReverseService", "ErrorInterceptor", "throwError");

		rs.throwError();

		AssertEquals(ArrayLen(request.callstack),2);
		AssertEquals(ArrayToList(request.callstack),"throwError,onError");
	}
}