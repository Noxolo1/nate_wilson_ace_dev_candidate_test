function requireApiKey(req, res, next){

    // return 401 Unauthorized if apikey invalid 

    // define header
    const apiKey =  req.header("x-api-key");

    if (!apiKey || apiKey != process.env.API_KEY){
        return res.status(401).json({error: "Unauthorized"})
    }

    next();
}

module.exports = {requireApiKey};